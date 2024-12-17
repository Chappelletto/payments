shared_context "requires authentification" do
  let(:auth_headers) { {"X-Auth-Token" => "api-token"} }
  let(:request_headers) { {} }

  before do
    request_headers.merge!(auth_headers)
  end

  context "when without auth token" do
    let(:auth_headers) { {} }

    it "returns error" do
      expect(subject).to have_http_status(401)
      expect(parsed_body).to eq(error: "X-Auth-Token is missing")
    end
  end

  context "when invalid token" do
    let(:auth_headers) { {"X-Auth-Token" => "123"} }

    it "return error" do
      expect(subject).to have_http_status(401)
      expect(parsed_body).to eq(error: "X-Auth-Token is invalid")
    end
  end
end
