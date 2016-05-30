require 'spec_helper'
require 'minichat/message'
require 'digest'

describe Minichat::Message do
  describe '::parse' do
    context 'correct digest' do
      let(:raw_message) do
        "034374626a973475fdf085c827153add9fc452914422cc20e241e75bd6840502|info|Welcome Edo".chomp
      end

      before do
        @message = Minichat::Message.parse(raw_message)
      end

      it 'should return Message object' do
        expect(@message.is_a?(Minichat::Message)).to be true
      end

      it 'should hexdigest should be match' do
        expect(@message.hexdigest).to eq '034374626a973475fdf085c827153add9fc452914422cc20e241e75bd6840502'
      end
    end

    context 'incorrect digest' do
      let(:raw_message) do
        "0000000000000000000|info|Welcome Edo".chomp
      end

      it 'should raise an error' do
        expect { Minichat::Message.parse(raw_message) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '::new' do
    let(:message) { Minichat::Message.new(:chat, :alice, :bob, 'Hi Bob') }

    it 'should have correct SHA256 digest' do
      expect(message.hexdigest).to eq(Digest::SHA256.new.hexdigest('chatalicebobHi Bob'))
    end

    it 'should have correct type' do
      expect(message.type).to eq(:chat)
    end

    it 'should have correct number of arguments' do
      expect(message.args.length).to eq(3)
    end
  end
end
