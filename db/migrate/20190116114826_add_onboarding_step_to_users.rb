class AddOnboardingStepToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :onboarding_step, :integer
  end
end
