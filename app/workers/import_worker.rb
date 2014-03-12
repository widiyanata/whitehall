class ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform(id, options={})
    Import.using_separate_connection do
      @import = Import.find(id)
      @import.perform(options)
    end
  end
end
