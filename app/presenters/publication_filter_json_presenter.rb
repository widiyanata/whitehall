class PublicationFilterJsonPresenter < DocumentFilterPresenter
  include FilterPresenterHelper

  def result_type
    "publication"
  end
end
