# frozen_string_literal: true

# Run: ruby ~/.dotfiles/agents/skills/bin/test/memory_test.rb
require "minitest/autorun"
require "tmpdir"
require "fileutils"

ROOT = Dir.mktmpdir("memory-test")
ENV["MEMORY_CORPUS_DIR"] = File.join(ROOT, "knowledge")
ENV["MEMORY_SKILL_PATH"] = File.join(ROOT, "SKILL.md")
ENV["MEMORY_GITHUB_DIR"] = File.join(ROOT, "github.com")
load File.expand_path("../memory", __dir__)
Minitest.after_run { FileUtils.rm_rf(ROOT) }

class MemoryTest < Minitest::Test
  K = Memory::CORPUS_DIR

  def setup
    FileUtils.rm_rf(K)
    FileUtils.mkdir_p(K)
    File.write(Memory::TOPICS_PATH, "# Topics\n\n- `cookies` — cookie scoping\n- `ci` — CI pipelines\n")
    note "a-cookie", %w[topic/cookies], "Cookie note"
    note "b-ci", %w[topic/ci repo/vimeows/vimeo], "CI note"
    note "c-lost", %w[topic/unfiled], "Unfiled note"
    note "d-other", %w[topic/ci], "Other CI"
  end

  def note(slug, tags, title)
    File.write(File.join(K, "#{slug}.md"), "---\ntype: reference\ntags: [#{tags.join(", ")}]\ncreated: 2026-10-08\n---\n\n# #{title}\n\nBody.\n")
  end

  def slugs(lines) = lines.map { |l| l[/\(([^)]+)\.md\)/, 1] }.sort

  # list

  def test_topic_lookup_returns_matches_plus_unfiled
    assert_equal %w[a-cookie c-lost], slugs(Memory::Lister.new(topics: %w[cookies]).run)
  end

  def test_repo_adds_notes_outside_the_requested_topics
    assert_equal %w[a-cookie b-ci c-lost], slugs(Memory::Lister.new(topics: %w[cookies], repos: %w[vimeows/vimeo]).run)
  end

  def test_repo_only_lookup_skips_unfiled
    assert_equal %w[b-ci], slugs(Memory::Lister.new(repos: %w[vimeows/vimeo]).run)
  end

  def test_unknown_topic_is_rejected
    assert_raises(Memory::UsageError) { Memory::Lister.new(topics: %w[nope]).run }
  end

  # repo detection

  def test_parse_url_forms
    {
      "git@github.com:vimeows/vimeo.git" => "vimeows/vimeo",
      "git@personal.github.com:jackweinbender/dotfiles.git" => "jackweinbender/dotfiles",
      "git@github.com:/acme/widgets.git" => "acme/widgets", # insteadOf rewrite of an https URL
      "https://github.com/vimeows/player-backend" => "vimeows/player-backend",
      "ssh://git@github.com:22/acme/widgets.git" => "acme/widgets",
      "not a url" => nil
    }.each { |url, want| want ? assert_equal(want, Memory::Repo.parse_url(url), url) : assert_nil(Memory::Repo.parse_url(url), url) }
  end

  def test_workspace_root_detects_every_worktree_repo
    ws = File.join(ROOT, "ws")
    { "vimeows/vimeo-feat" => "git@github.com:vimeows/vimeo.git",
      "acme/widgets-main" => "https://github.com/acme/widgets.git" }.each do |dir, url|
      path = File.join(ws, ".worktrees", dir)
      FileUtils.mkdir_p(path)
      system("git", "-C", path, "init", "-q", exception: true)
      system("git", "-C", path, "remote", "add", "origin", url, exception: true)
    end
    assert_equal %w[acme/widgets vimeows/vimeo], Memory::Repo.detect(ws)
  end

  # index

  def test_index_regenerates_facets_and_keeps_curated_hooks
    Memory::Corpus.reconcile
    text = File.read(Memory::INDEX_PATH).sub("](b-ci.md) — Body.", "](b-ci.md) — curated hook")
    File.write(Memory::INDEX_PATH, text)
    note "b-ci", %w[topic/cookies repo/vimeows/vimeo], "CI note"

    Memory::Corpus.reconcile
    line = File.readlines(Memory::INDEX_PATH, chomp: true).find { |l| l.include?("(b-ci.md)") }
    assert_equal "- [CI note](b-ci.md) — curated hook · topic/cookies repo/vimeows/vimeo", line
    assert_equal "curated hook", Memory::Corpus.index_entries["b-ci"][:hook]
  end

  # add

  def add(tags) = Memory::Adder.new(slug: "new", type: "reference", tags: tags, title: "T", summary: "s")

  def test_add_requires_a_known_topic
    assert_raises(Memory::UsageError) { add(%w[free-form]) }
    assert_raises(Memory::UsageError) { add(%w[topic/nope]) }
    assert_raises(Memory::UsageError) { add(%w[topic/ci repo/not-a-repo]) }
  end

  def test_add_accepts_unfiled_and_repo
    add(%w[topic/unfiled repo/vimeows/vimeo])
  end
end
