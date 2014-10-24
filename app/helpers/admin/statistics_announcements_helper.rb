module Admin::StatisticsAnnouncementsHelper

  def organisations_list(organisations)
    organisations.join(', ')
  end

end
