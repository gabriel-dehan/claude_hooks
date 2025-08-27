# Common API Methods

Those methods are available in **all hook types** and are inherited from `ClaudeHooks::Base`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

| Method | Description |
|--------|-------------|
| `input_data` | Input data reader |
| `session_id` | Get the current session ID |
| `transcript_path` | Get path to the transcript file |
| `cwd` | Get current working directory |
| `hook_event_name` | Get the hook event name |
| `read_transcript` | Read the transcript file |
| `transcript` | Alias for `read_transcript` |

## Hook State Methods
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

| Method | Description |
|--------|-------------|
| `allow_continue!` | Allow Claude to continue (default) |
| `prevent_continue!(reason)` | Stop Claude with reason |
| `suppress_output!` | Hide stdout from transcript |
| `show_output!` | Show stdout in transcript (default) |
| `clear_specifics!` | Clear hook-specific output |

## Output Object Methods

From a hook, you can always access the `output` object via `hook.output`. 
This object provides helpers to access output data, for merging multiple outputs as well as sending the right exit codes and data back to Claude Code.

### Output data access

| Method | Description |
|--------|-------------|
| `output` | Output object accessor |
| `output_data` | RAW output data accessor |
| `output.to_json` | Generates a JSON string of the output |
| `continue?` | Check the hook state to see if Claude Code should continue |
| `suppress_output?` | Check if output should be suppressed |

### Output data merging
For each hook type, the `output` object provides a **class method** `merge` that will try to intelligently merge multiple hook results, e.g. `ClaudeHooks::Output::UserPromptSubmit.merge(output1, output2, output3)`.

| Method | Description |
|--------|-------------|
| `merge(*outputs)` | Intelligently merge multiple outputs into a single output |

### Exit Control and Yielding back to Claude Code

| Method | Description |
|--------|-------------|
| `exit_and_output` | Prints the output to the correct stream (`STDIN` / `STDERR`) and exit with correct code |
| `exit_code` | Get the calculated exit code based on hook-specific logic |
| `output_stream` | Get the output stream (:stdout or :stderr) |

## Configuration and Utility Methods

### Utility Methods
| Method | Description |
|--------|-------------|
| `log(message, level: :info)` | Log to session-specific file (levels: :info, :warn, :error) |

### Configuration Methods
| Method | Description |
|--------|-------------|
| `home_claude_dir` | Get the home Claude directory (`$HOME/.claude`) |
| `project_claude_dir` | Get the project Claude directory (`$CLAUDE_PROJECT_DIR/.claude`, or `nil`) |
| `home_path_for(relative_path)` | Get absolute path relative to home Claude directory |
| `project_path_for(relative_path)` | Get absolute path relative to project Claude directory (or `nil`) |
| `base_dir` | Get the base Claude directory (**deprecated**) |
| `path_for(relative_path, base_dir=nil)` | Get absolute path relative to specified or default base dir (**deprecated**) |
| `config` | Access the merged configuration object |
| `config.get_config_value(env_key, config_file_key, default)` | Get any config value with fallback |
| `config.logs_directory` | Get logs directory path (always under home directory) |
| `config.your_custom_key` | Access any custom config via method_missing |
