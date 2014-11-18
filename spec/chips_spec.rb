require 'spec_helper'

describe P4::Chips do
  it "should be a module" do
    expect(P4::Chips.class).to eql Module
  end

  let(:config_in_block){
    P4::Chips.configure do |c|
      return c
    end
  }

  it ".config" do
    expect(P4::Chips.respond_to? :config).to be true
    expect{P4::Chips.config.class.should eq(Hashie::Mash)}
    P4::Chips.config.some_param = "test01"
    expect{P4::Chips.config.some_param.to eq("test01")}
  end

  it ".configure" do
    expect(P4::Chips.respond_to? :configure).to be true
    expect{config_in_block.class.should eq(Hashie::Mash)}

    config_in_block.some_param = "test02"
    expect{P4::Chips.config.some_param.to eq("test02")}
  end
end
