class HomeController < PublicFacingController
  layout 'frontend'

  enable_request_formats feed: [:atom]

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document).limit(10)
  end

  def get_involved
    @open_consultation_count = Consultation.published.open.count
    @closed_consultation_count = Consultation.published.closed_since(1.year.ago).count
    @next_closing_consultations = decorate_collection(Consultation.published.open.order("closing_at asc").limit(1), PublicationesquePresenter)
    @recently_opened_consultations = decorate_collection(Consultation.published.open.order("opening_at desc").limit(3), PublicationesquePresenter)
    @recent_consultation_outcomes = decorate_collection(Consultation.published.closed.responded.order("closing_at desc").limit(3), PublicationesquePresenter)
    @take_part_pages = TakePartPage.in_order
  end

  def history_king_charles_street
  end

  def history_lancaster_house
  end
end
