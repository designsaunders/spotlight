require 'spec_helper'

describe Spotlight::Resource do
  before do
    Spotlight::Resource.any_instance.stub(:reindex)
  end

  describe ".class_for_resource" do
    let(:thing) { double }
    let(:type_a) { double("TypeA", weight: 10) }
    let(:type_b) { double("TypeB", weight: 5) }
    let(:providers) { [type_a, type_b] }
    subject { Spotlight::Resource.class_for_resource(thing) }

    before do
      Spotlight::Resource.stub(providers: providers)
    end

    it "should return a class that can provide indexing for the resource" do
      type_a.should_receive(:can_provide?).with(thing).and_return(true)
      type_b.should_receive(:can_provide?).with(thing).and_return(false)
      expect(subject).to eq type_a
    end

    it "should return the lowest weighted class that can provide indexing for the resource" do
      type_a.should_receive(:can_provide?).with(thing).and_return(true)
      type_b.should_receive(:can_provide?).with(thing).and_return(true)
      expect(subject).to eq type_b
    end
  end

  describe "#to_solr" do
    it "should include a reference to the resource" do
      subject.stub(type: "Spotlight::Resource::Something", id: 15)
      expect(subject.to_solr).to include spotlight_resource_id_ssim: "spotlight/resource/somethings:15"
    end

    it "should include a reference to the url" do
      subject.stub(type: "Spotlight::Resource::Something", id: 15, url: "info:something")
      expect(subject.to_solr).to include spotlight_resource_url_ssim: "info:something"
    end
  end

  describe "#becomes_provider" do
    it "should convert the resource to a provider-specific resource" do
      SomeClass = Class.new(Spotlight::Resource)
      Spotlight::Resource.stub(class_for_resource: SomeClass)
      expect(subject.becomes_provider).to be_a_kind_of(SomeClass)
      expect(subject.becomes_provider.type).to eq "SomeClass"
    end
  end

  it "should reindex after save" do
    subject.should_receive(:reindex)
    subject.should_receive(:update_index_time!)
    subject.data = {a: 1}
    subject.save!
  end

  it "should store arbitrary data" do
    subject.data[:a] = 1
    subject.data[:b] = 2

    expect(subject.data[:a]).to eq 1
    expect(subject.data[:b]).to eq 2
  end

  describe "#update_index_time!" do
    it "should update the index_time column" do
      subject.should_receive(:update_columns).with(hash_including(:indexed_at))
      subject.update_index_time!
    end
  end
end
