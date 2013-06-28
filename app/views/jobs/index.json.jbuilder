json.array!(@jobs) do |job|
  json.extract! job, :name, :script
  json.url job_url(job, format: :json)
end
