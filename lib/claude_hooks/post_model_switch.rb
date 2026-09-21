# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PostModelSwitch < Base
    def self.hook_type
      'PostModelSwitch'
    end

    def self.input_fields
      %w[from_model to_model requested_model source]
    end

    # === INPUT DATA ACCESS ===
    #
    # PostModelSwitch receives the same fields as PreModelSwitch, with two extra
    # `source` values ("auto", "resume"). `requested_model` is null when source is
    # "auto", and the restored setting when source is "resume".

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
    # PostModelSwitch can't block (the model already changed); it only adds context.
    # Its stdout is also shown to Claude as context.

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'additionalContext' => context
      }
    end
    alias_method :add_context!, :add_additional_context!
  end
end
