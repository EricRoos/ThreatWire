module ReportingService
  def self.fetch_ssh_rejection_countries(limit: nil)
    report_definition = {
      data_source: "v_ssh_rejection_countries",
      projection: [
        :ip_location,
        :count
      ],
      order: {
        key: :count,
        direction: :desc
      }
    }
    fetch_report_from_definition(report_definition)
  end

  def self.fetch_report_from_definition(report_definition)
    table = Arel::Table.new(report_definition[:data_source])
    query = Arel::SelectManager.new
      .project(*report_definition[:projection])
      .from(table)
      .order(table[report_definition[:order][:key]].send(report_definition[:order][:direction]))

    query.take(limit) if limit

    ActiveRecord::Base.connection.exec_query(query.to_sql).rows
  end
end
