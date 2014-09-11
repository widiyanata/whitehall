class AnnouncementFilterJsonPresenter < DocumentFilterPresenter
  include FilterPresenterHelper

  def result_type
    "announcement"
  end
end
