# frozen_string_literal: true

require "spec_helper"

RSpec.describe SidekiqUniqueJobs::Unlockable do
  let(:key)          { SidekiqUniqueJobs::Key.new(digest) }
  let(:digest)       { item["digest"] }
  let(:lock)         { SidekiqUniqueJobs::Lock.new(key) }
  let(:args)         { [1, 2] }
  let(:jid)          { SecureRandom.hex(16) }
  let(:queue)        { "customqueue" }
  let(:lock_ttl)     { 7_200 }
  let(:lock_timeout) { 0 }
  let(:worker_class) { MyUniqueJob }
  let(:item) do
    SidekiqUniqueJobs::Job.prepare(
      "class" => worker_class,
      "queue" => queue,
      "args" => args,
      "lock_ttl" => lock_ttl,
      "jid" => jid,
    )
  end

  describe ".unlock" do
    subject(:unlock) { described_class.unlock(item) }

    specify do
      expect { push_item(item) }.to change { unique_keys.size }.by(3)
      expect { unlock }.to change { unique_keys.size }.by(-2)
    end
  end

  describe ".unlock!" do
    subject(:unlock!) { described_class.unlock!(item) }

    specify do
      expect { push_item(item) }.to change { unique_keys.size }.by(3)
      expect { unlock! }.to change { unique_keys.size }.by(-2)
    end
  end

  describe ".delete" do
    subject(:delete) { described_class.delete(item) }

    specify do
      expect { push_item(item) }.to change { unique_keys.size }.by(3)
      expect { delete }.to change { unique_keys.size }.by(0)
    end
  end

  describe ".delete!" do
    subject(:delete!) { described_class.delete!(item) }

    specify do
      expect { push_item(item) }.to change { unique_keys.size }.by(3)
      expect { delete! }.to change { unique_keys.size }.by(-3)
    end
  end

  describe ".limit_reached?" do
    subject(:limit_reached?) { described_class.limit_reached?(worker_class, args, queue) }

    it "returns false" do
      expect(limit_reached?).to be false
    end

    context "when item pushed" do
      it "returns true" do
        expect { push_item(item) }.to change { unique_keys.size }.by(3)
        expect(limit_reached?).to be true
      end
    end
  end
end
