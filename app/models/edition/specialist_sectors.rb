module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy
  end

  def specialist_sector_tags
    specialist_sectors.map(&:tag)
  end

  def specialist_sector_tags=(sector_tags)
    self.specialist_sectors = Array(sector_tags).reject(&:blank?).map do |tag|
      self.specialist_sectors.where(tag: tag).first_or_initialize
    end
  end
end