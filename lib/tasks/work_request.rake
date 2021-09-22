# frozen_string_literal: true

namespace :work_request do
  desc 'insert types of work to lokic DB'
  task insert_types: :environment do
    types = [
      { type_of_work: 1, name: %(Scrape) },
      { type_of_work: 1, name: %(FOIA Request) },
      { type_of_work: 1, name: %(Manual Data Gather) },
      { type_of_work: 1, name: %(Marketwatch) },
      { type_of_work: 1, name: %(HLE Story Template Creation / Production) },
      { type_of_work: 1, name: %(Creation of new client or projects/publications in Pipeline) },
      { type_of_work: 1, name: %(Direct data delivery (in a spreadsheet or csv)) },
      { type_of_work: 1, name: %(Data to Limpar) },
      { type_of_work: 1, name: %(Lumen work) },
      { type_of_work: 1, name: %(Tool building, maintenance, or improvement) },
      { type_of_work: 1, name: %(Human Resources (hiring, training, writing documentation, etc)) },
      { type_of_work: 1, name: %(Report request (e.g., "How many of this or that have we done so far, etc.", "How much did we spend?")) }
    ]

    types.each { |row| TypeOfWork.find_or_create_by!(work: row[:type_of_work], name: row[:name]) }
  end

  task insert_underwriting_projects: :environment do
    types = [
      { name: 'RAE news on vote fraud' },
      { name: 'RPAC news in six states' }
    ]

    types.each { |row| UnderwritingProject.find_or_create_by!(name: row[:name]) }
  end

  task insert_revenue_types: :environment do
    types = [
      { name: "Features Production Services - 101 - (AIC) (includes features and 'enterprise' reporting)" },
      { name: 'Print Pagination Services - 102 - (AIC) (Only pagination part -- not news production)' },
      { name: 'Pipeline Subscriptions - 103 - (AIC) (Pipeline editorial workflow software is part of ASC)' },
      { name: 'Editorial Data Services - 201 - (RIC) (Briefs are here. PRRs and HLE)' },
      { name: 'Custom Data Services - 202 - (RIC) (Includes document retrieval, FOIA, Vote Ref work, etc.' },
      { name: 'Roseland Subscriptions - 203 - (RIC)' },
      { name: 'Lumen Subscription - 301 - (ASC)' },
      { name: 'Story Promotion - 302 - (ASC) (Story promotion fees live here. All run through Lumen)' },
      { name: 'Marketing Services - 303 - (ASC) (Managing marketing/social campains)' },
      { name: 'Web operations - 401 - (WSC) (Includes web hosting & app management)' },
      { name: 'Sales consulting - 501 - (CNS)' },
      { name: 'Operations Consulting - 502 - (CNS) (Can include accounting)' },
      { name: 'Strategy Consulting - 601 - (PMA)' },
      { name: 'News Underwriting - 602 - (PMA)' },
      { name: 'BlockShopper.com - 701 - (CIC) (Includes advertising rev)' },
      { name: 'Advertising services - 702 - (CIC) (Revenue from managing advertising on Record, LGIS, etc.)' },
      { name: 'Strategic Consulting - 801 - (TCN) (Project/strategic management from the TCN team)' },
      { name: 'Search Services - 901 - (SPC) (SEO, Search Consulting, Rep Management)' }
    ]

    types.each { |row| RevenueType.find_or_create_by!(name: row[:name]) }
  end

  task insert_priority: :environment do
    priorities = [
      { name: 'Urgent 1 - stop everything else, even other urgent tasks' },
      { name: 'Urgent 2 - stop any non-urgent tasks, and do this alongside with other urgent tasks' },
      { name: "High Priority 1 - Don't stop what you're doing, but as soon as you finish current tasks, move this to the top" },
      { name: 'High Priority 2 - Put it near the top of the queue' },
      { name: 'Normal - Put it in the queue and get it going soon; but it can be put on hold for urgent and high priority tasks' },
      { name: "Low Priority - This is a great thing to do ... when you get a chance. Try to fit it in; otherwise, don't forget about it" }
    ]

    priorities.each { |row| RequestedWorkPriority.find_or_create_by!(name: row[:name]) }
  end
end
