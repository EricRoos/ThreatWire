# frozen_string_literal: true

class FactTableComponent < ViewComponent::Base

  def self.from_report(report)
    new(
      facts: report.data,
      columns: report.headers.to_a.map { |d| {attribute: d[0], header: d[1]} }
    )
  end

  def initialize(facts:, columns:)
    @facts = facts
    @columns = columns
  end

  attr_reader :facts, :columns
end
