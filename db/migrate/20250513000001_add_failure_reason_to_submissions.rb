class AddFailureReasonToSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :failure_reason, :text
  end
end
