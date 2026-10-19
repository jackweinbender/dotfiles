# frozen_string_literal: true

# Run: ruby ~/.dotfiles/agents/skills/bin/test/workspace_test.rb
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"

ROOT = Dir.mktmpdir("workspace-test")
ENV["WORKSPACE_PASEO_CONFIG"] = File.join(ROOT, "config.json")
load File.expand_path("../workspace", __dir__)
Minitest.after_run { FileUtils.rm_rf(ROOT) }

class EditorTest < Minitest::Test
  def test_resolve_requires_an_explicit_editor
    assert_raises(Workspace::UsageError) { Workspace::Editor.resolve(nil) }
    assert_raises(Workspace::UsageError) { Workspace::Editor.resolve("  ") }
  end

  def test_resolve_never_infers_from_the_calling_session
    ENV["CLAUDECODE"] = "1"
    assert_raises(Workspace::UsageError) { Workspace::Editor.resolve(nil) }
  ensure
    ENV.delete("CLAUDECODE")
  end

  def test_resolve_returns_the_explicit_value
    assert_equal "claude", Workspace::Editor.resolve(" claude ")
  end

  def test_paseo_is_recognised_by_command_name
    assert Workspace::Editor.paseo?("paseo")
    refute Workspace::Editor.paseo?("claude")
    refute Workspace::Editor.paseo?("opencode --prompt x")
  end

  def test_command_seeds_per_tool
    assert_equal "claude", Workspace::Editor.command("claude")
    assert_equal "claude Read\\ it", Workspace::Editor.command("claude", "Read it")
    assert_equal "opencode --prompt Read\\ it", Workspace::Editor.command("opencode", "Read it")
  end
end

class PaseoTest < Minitest::Test
  def write_config(profiles)
    File.write(Workspace::Paseo::CONFIG_PATH, JSON.dump({ "daemon" => { "agentProfiles" => profiles } }))
  end

  def test_profile_is_read_by_name
    write_config([{ "name" => "Architect", "provider" => "claude", "model" => "m", "modeId" => "auto", "thinkingOptionId" => "high" }])
    assert_equal "m", Workspace::Paseo.profile["model"]
  end

  def test_missing_profile_is_an_error
    write_config([{ "name" => "Other" }])
    assert_raises(Workspace::Error) { Workspace::Paseo.profile }
  end

  def test_missing_config_is_an_error
    FileUtils.rm_f(Workspace::Paseo::CONFIG_PATH)
    assert_raises(Workspace::Error) { Workspace::Paseo.profile }
  end

  def test_run_flags_materialize_the_profile
    flags = Workspace::Paseo.run_flags("provider" => "claude", "model" => "m", "modeId" => "auto", "thinkingOptionId" => "high")
    assert_equal %w[--provider claude/m --mode auto --thinking high], flags
  end

  def test_run_flags_omit_absent_values
    assert_equal %w[--provider claude], Workspace::Paseo.run_flags("provider" => "claude")
  end
end
