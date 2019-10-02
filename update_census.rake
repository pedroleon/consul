
# = update:census rake task
#
# == Pourpose 
# === Problem description
# We want to downgrade the user accounts that were verified with census (level_two_or_three scope)
# when they are removed from census. So, if a citizen changes his residence, will lose the verification.

# === Solution
# This solution will run a rake task that will re-check the verified users 
# daily. When a user has been removed from Census, the user is downgraded to level 1.

# === Implementation (pseudocode)
# - This task check all verified users
# - Will stop and raise error if the % of users to downgrade > CENSUS_UPDATE_SECURITY_PERCENTAGE_THREESHOLD 
# - For each verified user will check if is still in census (it makes a call per user to the CensusApi)
#   - If the verified user is not in census anymore, will:
#     - Downgrade it.
#     - Notify about the downgrade

# === Configuration
# The task settings are configured using secrets.yml

# *Rails.secrets.census_updater.max_downgrade_percentage_threshold*: integer between 0..100. default is: 1%.
#   Represents the % of users that can be downgraded, if the % found is bigger, the process will fail with an exception.
#   Ex: When value is 1: If more thant the 1% of the verified users are set to downgrade, the task will stop and raise and exception.
#   Ex: When value is 100%: The task will not stop even if all users are set to downgrade.

# *Rails.secrets.census_updater.notify_when_downgrade*:boolean. Default is true.
#   When true: Will send an email about the account update to the user. 
#   When false: Will not notify to the user.
#
# === Recomendations:
#
# - Is recomended to run this task using a cron job max once a day
# - Run it in low traffic hours: This task will potentially generate a big amount of CensusApi calls,  

# === Caveats during updates
# *Prevent masive downgrades*
# Depending of the Census API and the CensusApiCaller implementation
# there are risk of identify as deleted users some that are still in census
# in some situations, for example: 
# - When Census service is down (or its database) and CensusApiCaller returns false in this situation
# - When Census service changes its behaviour (not a regular situation, but can happend)
# Because of that is mandatory to configure CENSUS_UPDATE_SECURITY_PERCENTAGE_THREESHOLD

namespace :census do

  desc 'Ensures users of level two_or_three are still valid in census. If some use is not valid, level will be downgraded.'
  task synchronize: :environment do

    notify_when_downgrade = Rails.secrets.census_updater.notify_when_downgrade
    max_downgrade_percentage_threshold = Rails.secrets.census_updater.max_downgrade_percentage_threshold
    
    CensusUpdater.update_with_census(  
      users_scope: User.level_two_or_three, 
      notify_when_downgrade: notify_when_downgrade,
      max_downgrade_percentage_threshold: max_downgrade_percentage_threshold 
    )
end
