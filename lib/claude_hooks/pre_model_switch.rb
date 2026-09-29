# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PreModelSwitch < Base
    def self.hook_type
      'PreModelSwitch'
    end

    def self.input_fields
      %w[from_model to_model requested_model source]
    end

    # === INPUT DATA ACCESS ===

    def from_model
      @input_data['from_model'] || @input_data['fromModel']
    end

    def to_model
      @input_data['to_model'] || @input_data['toModel']
    end

    def requested_model
      @input_data['requested_model'] || @input_data['requestedModel']
    end

    def source
      @input_data['source']
    end

    def context_tokens
      @input_data['context_tokens'] || @input_data['contextTokens']
    end

    def prompt_cache_warm
      @input_data['prompt_cache_warm'] || @input_data['promptCacheWarm']
    end

    def cache_ttl
      @input_data['cache_ttl'] || @input_data['cacheTtl']
    end

    def estimated_cache_write_usd
      @input_data['estimated_cache_write_usd'] || @input_data['estimatedCacheWriteUsd']
    end

    def pricing
      @input_data['pricing']
    end

    # === OUTPUT DATA HELPERS ===
    #
    # PreModelSwitch mirrors PreToolUse's permissionDecision API (allow/deny/ask).
    # It does not accept 'defer', 'updatedInput', or 'additionalContext'.

    def approve!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'allow',
        'permissionDecisionReason' => reason
      }
    end
    alias_method :allow!, :approve!

    def deny!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'deny',
        'permissionDecisionReason' => reason
      }
    end
    alias_method :block_switch!, :deny!

    def ask!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'ask',
        'permissionDecisionReason' => reason
      }
    end

    # Top-level decision:block also cancels the switch (equivalent to exit 2).
    def block!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end
  end
end
