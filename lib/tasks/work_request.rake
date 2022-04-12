# frozen_string_literal: true

namespace :work_request do
  desc 'Insert initial data to lokic DB'
  task insert_initial_data: :environment do
    types = [
      { work: 1, hidden: false, name: %(Scrape) },
      { work: 1, hidden: false, name: %(FOIA Request) },
      { work: 1, hidden: false, name: %(Manual Data Gather) },
      { work: 1, hidden: false, name: %(Marketwatch) },
      { work: 1, hidden: false, name: %(HLE Story Template Creation / Production) },
      { work: 1, hidden: false, name: %(Creation of new client or projects/publications in Pipeline) },
      { work: 1, hidden: false, name: %(Direct data delivery (in a spreadsheet or csv)) },
      { work: 1, hidden: false, name: %(Data to Limpar) },
      { work: 1, hidden: false, name: %(Lumen work) },
      { work: 1, hidden: false, name: %(Tool building, maintenance, or improvement) },
      { work: 1, hidden: false, name: %(Human Resources (hiring, training, writing documentation, etc)) },
      { work: 1, hidden: false, name: %(Report request (e.g., "How many of this or that have we done so far, etc.", "How much did we spend?")) }
    ]
    types.each { |row| WorkType.find_or_create_by!(row) }


    projects = [
      { hidden: false, name: 'RAE news on vote fraud' },
      { hidden: false, name: 'RPAC news in six states' }
    ]
    projects.each { |row| UnderwritingProject.find_or_create_by!(row) }


    types = [
      { hidden: false, name: "Features Production Services - 101 - (AIC) (includes features and 'enterprise' reporting)" },
      { hidden: false, name: 'Print Pagination Services - 102 - (AIC) (Only pagination part -- not news production)' },
      { hidden: false, name: 'Pipeline Subscriptions - 103 - (AIC) (Pipeline editorial workflow software is part of ASC)' },
      { hidden: false, name: 'Editorial Data Services - 201 - (RIC) (Briefs are here. PRRs and HLE)' },
      { hidden: false, name: 'Custom Data Services - 202 - (RIC) (Includes document retrieval, FOIA, Vote Ref work, etc.' },
      { hidden: false, name: 'Roseland Subscriptions - 203 - (RIC)' },
      { hidden: false, name: 'Lumen Subscription - 301 - (ASC)' },
      { hidden: false, name: 'Story Promotion - 302 - (ASC) (Story promotion fees live here. All run through Lumen)' },
      { hidden: false, name: 'Marketing Services - 303 - (ASC) (Managing marketing/social campains)' },
      { hidden: false, name: 'Web operations - 401 - (WSC) (Includes web hosting & app management)' },
      { hidden: false, name: 'Sales consulting - 501 - (CNS)' },
      { hidden: false, name: 'Operations Consulting - 502 - (CNS) (Can include accounting)' },
      { hidden: false, name: 'Strategy Consulting - 601 - (PMA)' },
      { hidden: false, name: 'News Underwriting - 602 - (PMA)' },
      { hidden: false, name: 'BlockShopper.com - 701 - (CIC) (Includes advertising rev)' },
      { hidden: false, name: 'Advertising services - 702 - (CIC) (Revenue from managing advertising on Record, LGIS, etc.)' },
      { hidden: false, name: 'Strategic Consulting - 801 - (TCN) (Project/strategic management from the TCN team)' },
      { hidden: false, name: 'Search Services - 901 - (SPC) (SEO, Search Consulting, Rep Management)' }
    ]
    types.each { |row| RevenueType.find_or_create_by!(row) }



    types = [
      { hidden: false, name: 'Fixed price' },
      { hidden: false, name: 'COGs dependent' }
    ]
    types.each { |row| InvoiceType.find_or_create_by!(row) }



    frequencies = [
      { hidden: false, name: 'Weekly' },
      { hidden: false, name: 'Semi-monthly' },
      { hidden: false, name: 'Monthly' },
      { hidden: false, name: 'Quarterly' },
      { hidden: false, name: 'Semi-annually' },
      { hidden: false, name: 'Annually' },
      { hidden: false, name: 'Completion of work' },
    ]
    frequencies.each { |row| InvoiceFrequency.find_or_create_by!(row) }



    priorities = [
      { name: 'Urgent 1 - stop everything else, even other urgent tasks' },
      { name: 'Urgent 2 - stop any non-urgent tasks, and do this alongside with other urgent tasks' },
      { name: "High Priority 1 - Don't stop what you're doing, but as soon as you finish current tasks, move this to the top" },
      { name: 'High Priority 2 - Put it near the top of the queue' },
      { name: 'Normal - Put it in the queue and get it going soon; but it can be put on hold for urgent and high priority tasks' },
      { name: "Low Priority - This is a great thing to do ... when you get a chance. Try to fit it in; otherwise, don't forget about it" }
    ]
    priorities.each { |row| Priority.find_or_create_by!(row) }
  end
end
