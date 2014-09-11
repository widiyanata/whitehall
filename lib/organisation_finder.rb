module OrganisationFinder
  def find_org(params)
    if params.has_key?(:organisation_id)
      Organisation.find(params[:organisation_id])
    elsif params.has_key?(:worldwide_organisation_id)
      WorldwideOrganisation.find(params[:worldwide_organisation_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
