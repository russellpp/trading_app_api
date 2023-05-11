# spec/services/jwt_token_spec.rb

require 'rails_helper'
require_relative '../../app/services/jwt_token'

RSpec.describe JwtToken do
  describe '#encode_token' do
    let(:payload) { { user_id: 123 } }

    it 'encodes a token with the given payload' do
      expect(JWT).to receive(:encode).with(payload, 'pp98JsxQ86')
      described_class.new.encode_token(payload)
    end
  end

  describe '#decoded_token' do
    context 'when auth header is present' do
      let(:auth_header) { 'Bearer some_token' }

      it 'decodes the token and returns the payload' do
        expect(JWT).to receive(:decode).with('some_token', 'pp98JsxQ86', true, { algorithm: 'HS256' }).and_return([{ 'user_id' => 123 }])
        expect(described_class.new.decoded_token(auth_header)).to eq({ 'user_id' => 123 })
      end
    end

    context 'when auth header is not present' do
      it 'returns nil' do
        expect(JWT).not_to receive(:decode)
        expect(described_class.new.decoded_token(nil)).to be_nil
      end
    end

    context 'when decoding fails' do
      let(:auth_header) { 'Bearer invalid_token' }

      it 'returns nil' do
        expect(JWT).to receive(:decode).and_raise(JWT::DecodeError)
        expect(described_class.new.decoded_token(auth_header)).to be_nil
      end
    end
  end
end
