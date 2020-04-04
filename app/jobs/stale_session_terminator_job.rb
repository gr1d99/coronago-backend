class StaleSessionTerminatorJob < ApplicationJob
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform
    Session.where(status: 'in-progress').where("? - last_ping_time >= INTERVAL '10 minutes'", Time.now.utc).in_batches do |batch|
      batch.update_all("end_time=last_ping_time + (interval '10 minutes'),status=#{Session.statuses['done']}")
    end
  end
end
