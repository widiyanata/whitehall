module EditionPresenterHelper
  def as_hash
    {
      id: model.id,
      type: model.type.underscore,
      display_type: model.display_type,
      title: model.title,
      url: url,
      organisations: display_organisations.html_safe,
      display_date_microformat: display_date_microformat,
      public_timestamp: model.public_timestamp
    }
  end

  def url
    if model.respond_to? :link
      model.link
    else
      context.public_document_path(model)
    end
  end

  def link
    context.link_to model.title, url
  end

  def display_organisations
    organisations.map { |o| context.organisation_display_name(o) }.to_sentence
  end

  def display_date_microformat
    date_microformat(:public_timestamp)
  end

  def date_microformat(attribute_name)
    context.render_datetime_microformat(model, attribute_name) {
      context.l(model.send(attribute_name).to_date, format: :long_ordinal)
    }
  end

  def publication_collections
    if model.respond_to?(:part_of_published_collection?) && model.part_of_published_collection?
      links = model.published_document_collections.map do |dc|
        context.link_to(dc.title, context.public_document_path(dc))
      end
      "Part of a collection: #{links.to_sentence}"
    end
  end
end
