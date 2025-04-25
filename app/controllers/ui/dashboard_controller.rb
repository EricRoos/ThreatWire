class Ui::DashboardController < ApplicationController
  def show
    @report = ReportingService.fetch_ssh_rejection_countries
  end
end
