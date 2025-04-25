module ReportingService
  class Report
    attr_reader :headers, :data

    def initialize(headers: [], data: [])
      @headers = headers
      @data = data
    end
  end

  class BrokenReport < Report; end

  SSH_REJECTION_COUNTRIES_TOTALS_REPORT = {
    headers: {
      ip_location: "IP Location",
      count: "Count"
    },
    query: {
      data_source: "v_ssh_rejection_countries_totals",
      order: {
        key: :count,
        direction: :desc
      }
    }
  }

  SSH_REJECTION_COUNTRIES_REPORT = {
    headers: {
      access_timestamp: "Date",
      ip_location: "IP Location",
      count: "Count"
    },
    query: {
      data_source: "mv_ssh_rejection_countries_by_date",
      order: [
        {
          key: :access_timestamp,
          direction: :desc
        },
        {
          key: :count,
          direction: :desc
        }
      ]
    }
  }

  def self.fetch_ssh_rejection_countries_totals(limit: nil)
    fetch_report_from_definition(SSH_REJECTION_COUNTRIES_TOTALS_REPORT, limit:)
  end

  def self.fetch_ssh_rejection_countries(limit: nil)
    fetch_report_from_definition(SSH_REJECTION_COUNTRIES_REPORT, limit:)
  end

  def self.fetch_report_from_definition(report_definition, limit: nil)
    table = Arel::Table.new(report_definition[:query][:data_source])
    query = Arel::SelectManager.new
      .project(*report_definition[:headers].keys)
      .from(table)
      .order(
        *Array.wrap(report_definition[:query][:order]).map do |order|
          table[order[:key]].send(order[:direction])
        end
      )

    query.take(limit) if limit

    Report.new(
      headers: report_definition[:headers],
      data: ActiveRecord::Base.connection.exec_query(query.to_sql).rows
    )
  rescue StandardError => e
    Rails.logger.error("Error fetching report: #{e.message}")
    BrokenReport.new(
      headers: report_definition[:headers],
      data: []
    )
  end
end
