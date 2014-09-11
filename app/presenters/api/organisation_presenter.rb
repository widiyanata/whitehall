class Api::OrganisationPresenter < Api::BasePresenter
  def as_json(options = {})
    {
      id: context.api_organisation_url(model),
      title: model.name,
      format: model.organisation_type.name,
      updated_at: model.updated_at,
      web_url: Whitehall.url_maker.organisation_url(model),
      details: {
        slug: model.slug,
        abbreviation: model.acronym,
        logo_formatted_name: model.logo_formatted_name,
        organisation_brand_colour_class_name: model.organisation_brand_colour.try(:class_name),
        organisation_logo_type_class_name: model.organisation_logo_type.try(:class_name),
        closed_at: model.closed_at,
        govuk_status: model.govuk_status,
      },
      parent_organisations: parent_organisations,
      child_organisations: child_organisations,
    }
  end

  def links
    [
      [context.api_organisation_url(model), {'rel' => 'self'}]
    ]
  end

private
  def parent_organisations
    relative_organisations("parent")
  end

  def child_organisations
    relative_organisations("child")
  end

  def relative_organisations(relative)
    model.public_send("#{relative}_organisations").map do |org|
      {
        id: context.api_organisation_url(org),
        web_url: Whitehall.url_maker.organisation_url(org)
      }
    end
  end
end
