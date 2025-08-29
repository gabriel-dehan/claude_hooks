#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'time'
require 'octokit'
require 'diffy'

FIRECRAWL_API_KEY = ENV['FIRECRAWL_API_KEY']
GITHUB_TOKEN = ENV['GITHUB_TOKEN']
REPO = ENV['GITHUB_REPOSITORY'] || 'gabriel-dehan/claude_hooks'
DOC_URL = 'https://docs.anthropic.com/en/docs/claude-code/hooks'
DOC_PATH = 'docs/external/claude-hooks-reference.md'

class DocMonitor
  def initialize
    @client = Octokit::Client.new(access_token: GITHUB_TOKEN)
    @repo = REPO
  end

  def ensure_labels(labels)
    existing = @client.labels(@repo).map(&:name)
    (labels - existing).each do |name|
      @client.add_label(@repo, name, 'ededed')
    end
  rescue => e
    puts "⚠️ Failed to ensure labels exist: #{e.message}"
  end

  def fetch_documentation
    puts "🔍 Fetching documentation from #{DOC_URL}..."
    
    uri = URI('https://api.firecrawl.dev/v1/scrape')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 60
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{FIRECRAWL_API_KEY}"
    request['Content-Type'] = 'application/json'
    
    request.body = {
      url: DOC_URL,
      formats: ['markdown']
    }.to_json
    
    response = http.request(request)
    
    if response.code != '200'
      puts "❌ Error fetching documentation: #{response.code}"
      begin
        err = JSON.parse(response.body)
        puts JSON.pretty_generate(err)
      rescue
        puts response.body
      end
      exit 1
    end
    
    data = JSON.parse(response.body)
    data.dig('data', 'markdown') || ''
  end

  def get_previous_content
    return '' unless File.exist?(DOC_PATH)
    File.read(DOC_PATH)
  end

  def save_documentation(content)
    FileUtils.mkdir_p(File.dirname(DOC_PATH))
    File.write(DOC_PATH, content)
    puts "📝 Documentation saved to #{DOC_PATH}"
  end

  def generate_diff(old_content, new_content)
    Diffy::Diff.new(old_content, new_content, context: 3).to_s(:text)
  end

  def create_github_issue(diff_content)
    puts "📋 Creating GitHub issue..."
    
    # Ensure labels exist to avoid API validation errors
    ensure_labels(%w[documentation automated])
    
    # Truncate diff if too long for GitHub issue body
    truncated_diff = diff_content.length > 60000 ? "#{diff_content[0..59997]}..." : diff_content
    
    body = <<~BODY
      ## 📝 Claude Hooks Documentation Changes Detected
      
      The Claude Hooks documentation at [#{DOC_URL}](#{DOC_URL}) has been updated.
      
      ### Changes Summary
      
      <details>
      <summary>Click to expand full diff</summary>
      
      ```diff
      #{truncated_diff}
      ```
      
      </details>
      
      ### Next Steps
      
      1. Review the changes above
      2. Update any affected hook implementations if necessary
      3. Update local documentation if needed
      
      ---
      *This issue was automatically generated on #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')}*
    BODY
    
    begin
      issue = @client.create_issue(
        @repo,
        "📚 Claude Hooks Documentation Updated - #{Time.now.strftime('%Y-%m-%d')}",
        body,
        labels: ['documentation', 'automated']
      )
      
      puts "✅ Issue created successfully: #{issue.html_url}"
      issue.html_url
    rescue => e
      puts "❌ Failed to create issue: #{e.message}"
      nil
    end
  end

  def commit_changes
    puts "💾 Committing changes..."
    
    author_name = ENV['GIT_AUTHOR_NAME'] || 'github-actions[bot]'
    author_email = ENV['GIT_AUTHOR_EMAIL'] || 'github-actions[bot]@users.noreply.github.com'
    system('git', 'config', 'user.name', author_name)
    system('git', 'config', 'user.email', author_email)
    system('git', 'add', DOC_PATH)
    
    commit_message = "🤖 Update Claude Hooks documentation - #{Time.now.strftime('%Y-%m-%d')}"
    system('git', 'commit', '-m', commit_message)
    
    # Rebase to avoid non-fast-forward issues if repo changed
    system('git', 'pull', '--rebase')
    system('git', 'push')
    
    puts "✅ Changes committed to repository"
  end

  def run
    # Fetch current documentation
    current_content = fetch_documentation
    
    if current_content.empty?
      puts "❌ Failed to fetch documentation content"
      exit 1
    end
    
    # Get previous content
    previous_content = get_previous_content
    
    # Check if there are changes
    if current_content == previous_content
      puts "✅ No changes detected in the documentation"
      exit 0
    end
    
    puts "📝 Changes detected! Saving new version..."
    
    # Save the new documentation
    save_documentation(current_content)
    
    if previous_content.empty?
      puts "📝 First time fetching documentation, no issue created"
    else
      # Generate diff and create issue
      diff = generate_diff(previous_content, current_content)
      create_github_issue(diff)
    end
    
    # Commit changes
    commit_changes
    
    puts "✅ Documentation monitoring complete!"
  end
end

# Main execution
if __FILE__ == $0
  unless FIRECRAWL_API_KEY
    puts "❌ FIRECRAWL_API_KEY environment variable is not set"
    puts "Please add it as a GitHub secret"
    exit 1
  end
  
  unless GITHUB_TOKEN
    puts "❌ GITHUB_TOKEN environment variable is not set"
    exit 1
  end
  
  monitor = DocMonitor.new
  monitor.run
end