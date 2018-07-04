require 'sqlite3'
require 'singleton'

class QuestionDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end


class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id
  
  def self.all
    data = QuestionDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end
  
  def self.find_by_author_id(author_id)
    questions = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions 
      WHERE
        user_id = ?
    SQL
    return nil if questions.empty?
    
    questions.map { |question| Question.new(question) }
  end 
  
  def self.find_by_id(id)
    question = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions 
      WHERE
        id = ?
    SQL

    Question.new(question.first)
  end 
  
  def initialize(options)
   @id = options['id']
   @body = options['body']
   @title = options['title']
   @user_id = options['user_id']
  end

  def author 
    User.find_by_id(self.user_id)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
#end of class
end

class User
  attr_accessor :fname, :lname
  attr_reader :id
  
  def self.all
    data = QuestionDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end
  
  def self.find_by_id(id)
    # raise "not in db" unless @id
    
    user = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    
    User.new(user.first)
  end 
  
  def self.find_by_name(fname, lname)
    # raise "who dat?" unless @fname && @lname
    
    user = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    
    User.new(user.first)
  end
  
  def initialize(options)
   @id = options['id']
   @fname = options['fname']
   @lname = options['lname']
  end
  
  def authored_questions
    Question.find_by_author_id(self.id)
  end
  
  def authored_replies
    Reply.find_by_author_id(self.id)
  end 
  
  
  
#END OF CLASS  
end




class Reply
  attr_accessor :user_id, :questions_id, :body, :parent_id
  attr_reader :id

  def self.all
    data = QuestionDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies 
      WHERE
        id = ?
    SQL
    
    Reply.new(reply.first)
  end 
  
  def self.find_by_user_id(user_id)
    replies = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if replies.empty?
    
    replies.map { |reply| Reply.new(reply) }
  end
  
  def self.find_by_question_id(questions_id)
    replies = QuestionDatabase.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        replies 
      WHERE
        questions_id = ?
    SQL
    return nil if replies.empty?
    
    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
   @id = options['id']
   @user_id = options['user_id']
   @questions_id = options['questions_id']
   @body = options['body']
   @parent_id = options['parent_id']
  end 
  
  def author
    User.find_by_id(self.user_id)
  end
  
  def question
    Question.find_by_id(self.questions_id)
  end
  
  def parent_reply
    return nil if self.parent_id.nil?
    
    Reply.find_by_id(self.parent_id)
  end
  
  def child_replies
    id = self.id
    replies = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies 
      WHERE
        parent_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end

end

class QuestionFollow
  def self.followers_for_question_id(questions_id)
    users = QuestionDatabase.instance.execute(<<-SQL, questions_id)
      SELECT
        fname, lname
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      WHERE
        questions_id = ?
    SQL
    
    users.map { |user| User.new(user) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        title, body
      FROM
        questions
      JOIN
        question_follows ON question_follows.questions_id = questions.id
      WHERE
        user_id = ?
    SQL
    
    questions.map { |question| Question.new(question) }
  end
end
