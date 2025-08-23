module JsonApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def json_data
    json['data']
  end

  def json_included
    json['included']
  end

  def json_error
    json['error']
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

  def expect_relationship(relationship_name)
    resource = json_data.is_a?(Array) ? json_data.first : json_data
    expect(resource['relationships']).to have_key(relationship_name.to_s)
  end

  def expect_included_resources(expected_type, expected_count = nil)
    expect(json_included).to be_present
    included_of_type = json_included.select { |r| r['type'] == expected_type }
    expect(included_of_type.size).to eq(expected_count) if expected_count
    included_of_type
  end
end
