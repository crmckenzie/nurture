class Releases < Sinatra::Base

  before do
  end

  after do
    request.accept.each do | accept |
      case accept
      when true
      else # default to json
        response.body = response.body.to_json unless response.body.kind_of? String
        response.header["Content-Type"] = "application/json"
      end
    end
  end

  def halt_if_no_manifests(params)
    items = params[:manifests]
    has_items = items && items.size > 0
    halt HttpStatusCodes::FORBIDDEN, {:manifests => ['at least one manifest is required.']} unless has_items
  end

  def halt_if_manifests_have_been_released(params)
    manifests = Manifest.where({
      :name.in => params[:manifests],
      :release_id.ne => nil
      })

    errors = manifests.all.map {|m|
      "'#{m.name}' has already been released."
    }

    halt HttpStatusCodes::FORBIDDEN, {:manifests => errors} if errors.size > 0

  end

  post '/' do
    halt_if_no_manifests params
    halt_if_manifests_have_been_released params

    previous_release = Release.sort(:created_at).last
    release = Release.create

    params[:manifests].each do |row|
      manifest = Manifest.first({:name => row})
      manifest.release = release
      manifest.save
    end

    release.merge_application_versions(previous_release)
    release.save

    status 200
    body({:id => release.id.to_s})
  end

  get '/' do
    Release.all()
  end

  get '/:id' do
    status 200
    body Release.first({:id => params[:id]})
  end

end
