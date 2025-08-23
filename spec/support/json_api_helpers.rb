module JsonApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def json_data
    json['data']
  end

  def expect_json_response(status: :ok)
    expect(response).to have_http_status(status)
    expect(response.content_type).to include('application/')
  end

  def expect_collection_size(size)
    expect(json_data).to be_an(Array)
    expect(json_data.size).to eq(size)
  end

  def expect_resource_attributes(*attributes)
    resource = json_data.is_a?(Array) ? json_data.first : json_data
    attributes.each do |attr|
      expect(resource['attributes']).to have_key(attr.to_s)
    end
  end

  def expect_resource_id(expected_id)
    resource = json_data.is_a?(Array) ? json_data.first : json_data
    expect(resource['id']).to eq(expected_id.to_s)
  end

  def expect_resource_type(expected_type)
    resource = json_data.is_a?(Array) ? json_data.first : json_data
    expect(resource['type']).to eq(expected_type)
  end
end
