#!/usr/bin/env ruby

require 'rubygems'
require 'grit'

MASTER_BRANCH = "master"
MIRROR_DIR = File.join(ENV["HOME"], "Documents", "Projects", "mirrors")
REMOTE_NAME = "origin"
TRUNK = "trunk"

module Mirror
  extend self

  attr_accessor :repo

  def branch_locally!(name)
    unless branch_names.include?(name)
      puts "Creating local branch: #{name}"
      `git branch #{name} remotes/#{name}`
    end
  end

  def branch_names
    repo.branches.collect do |branch|
      branch.name
    end
  end

  def process(dir)
    puts "Processing #{dir}..."

    Dir.chdir(path = File.join(MIRROR_DIR, dir)) do
      puts `git svn fetch`

      @repo = Grit::Repo.new(path)

      # repo.branches.each do |branch|
      #   puts "Branch: #{branch.name}"
      # end

      repo.remotes.each do |remote|
        if remote.name =~ /^tags\/(.+)/
          tag!($1, remote.commit)
        else
          next if remote.name =~ /^(#{REMOTE_NAME}\/|#{TRUNK})/

          branch_locally!(remote.name)
          rebase_branch!(remote.name)
        end
      end

      rebase_branch!(MASTER_BRANCH, TRUNK)

      # repo.tags.each do |tag|
      #   puts "Tag: #{tag.name}"
      # end

      @repo = nil
    end
  end

  def rebase_branch!(name, remote = name)
    puts "Rebasing branch #{name}..."
    puts `git checkout -q #{name}      2> /dev/null`
    puts `git rebase remotes/#{remote} 2> /dev/null`
    puts `git checkout -q #{MASTER_BRANCH}`
  end

  def tag!(tag_name, commit)
    unless tag_names.include?(tag_name)
      puts "Applying tag '#{tag_name}'"

      # unfortunately this loses information about this person who actually made the commit
      `GIT_COMMITTER_DATE="#{remote.commit.date.strftime("%Y-%m-%d %H:%M")}" git tag #{tag_name}" #{remote.commit.id}`
    end
  end

  def tag_names
    repo.tags.collect do |tag|
      tag.name
    end
  end

  def run!
    Dir.foreach(MIRROR_DIR) do |entry|
      next if %w(. ..).include?(entry) || File.file?(entry)

      process(entry)
    end
  end
end

if __FILE__ == $0
  Mirror.run!
end
