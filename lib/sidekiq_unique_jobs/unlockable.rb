# frozen_string_literal: true

module SidekiqUniqueJobs
  # Utility module to help manage unique keys in redis.
  # Useful for deleting keys that for whatever reason wasn't deleted
  #
  # @author Mikael Henriksson <mikael@mhenrixon.com>
  module Unlockable
    module_function

    # Unlocks a job.
    # @param [Hash] item a Sidekiq job hash
    def unlock(item)
      SidekiqUniqueJobs::Job.add_digest(item)
      SidekiqUniqueJobs::Locksmith.new(item).unlock
    end

    # Unlocks a job.
    # @param [Hash] item a Sidekiq job hash
    def unlock!(item)
      SidekiqUniqueJobs::Job.add_digest(item)
      SidekiqUniqueJobs::Locksmith.new(item).unlock!
    end

    # Deletes a lock unless it has ttl
    #
    # This is good for situations when a job is locked by another item
    # @param [Hash] item a Sidekiq job hash
    def delete(item)
      SidekiqUniqueJobs::Job.add_digest(item)
      SidekiqUniqueJobs::Locksmith.new(item).delete
    end

    # Deletes a lock regardless of if it was locked or has ttl.
    #
    # This is good for situations when a job is locked by another item
    # @param [Hash] item a Sidekiq job hash
    def delete!(item)
      SidekiqUniqueJobs::Job.add_digest(item)
      SidekiqUniqueJobs::Locksmith.new(item).delete!
    end

    # Tests job is limit reached
    # @return [true] if job reached
    # @return [false] if job not reached
    def limit_reached?(worker_class, args = [], queue = nil)
      item = worker_class.sidekiq_options.merge({
        "class" => worker_class.to_s,
        "args" => args,
        "queue" => queue,
      }.compact)

      SidekiqUniqueJobs::Job.add_digest(item)
      !!SidekiqUniqueJobs::Locksmith.new(item).limit_reached?
    end
  end
end
