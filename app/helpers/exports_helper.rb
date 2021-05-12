# frozen_string_literal: true

module ExportsHelper
  def editor_questions
    {
      'q1' => 'Did you review a sample of at least 1000 random headlines (or, if less than 1000 stories, did you review all headlines)?',
      'q2' => 'Did we avoid problems with duplicate headlines in the same publication? (Both in this export and for future exports)',
      'q3' => 'Did the headlines avoid awkward wording?',
      'q4' => 'Would you be embarrassed by the headlines if your name was on the byline?',
      'q5' => 'If you would be embarrased by this, are there ways to improve the headlines?',
      'q6' => 'Did you open at least 5 stories in Pipeline and verify that the stories had suitable photographs, proper formatting, and correct publication assignments?',
      'q7' => "Did you select 3 'show' stories from the exported stories that are flawless and that we can show to prospective clients without further review, and these prospective clients are likely to like the story for its newsworthiness, clarity, accuracy, etc.?",
      'q8' => 'Are you satisfied accepting responsibility for the quality of these stories, that they are as good as we can make them given reasonable expectations of automated story types?'
    }
  end

  def manager_questions
    {
      'q1' => 'How many stories did you read?',
      'q2' => 'How many avoidable grammar errors did you find that editors should have caught?',
      'q3' => 'How many avoidable phrasing/awkwardness errors did you find that editors should have caught?',
      'q4' => 'How many avoidable style errors did you find that editors should have caught?',
      'q5' => 'How many avoidable factual errors did you find that editors should have caught?',
      'q6' => 'How many headlines did you read?',
      'q7' => 'How many headlines had errors or significant problems that editors should have caught?',
      'q8' => 'Paste example(s) of exported headlines with errors below:',
      'q9' => 'Paste example(s) of exported story errors below:'
    }
  end
end
