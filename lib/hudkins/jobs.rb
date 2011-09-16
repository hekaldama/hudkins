class Hudkins
  # this class is just a convenience wrapper around an array of jobs.
  # _FIX_ consider that Enumerable methods returns a Hudkins::Jobs obj instead of an array..
  class Jobs
    include Hudkins::Common
    include Enumerable

    def initialize(hudkins)
      @hudkins = hudkins
      data = @hudkins.get_parsed( "/api/json", :accept => "application/json" )
      @jobs = Array.new
      data["jobs"].each do |job|
        @jobs << Hudkins::Job.new( @hudkins, job )
      end
    end

    def inspect
      super
    end

    # Enumerable
    # This returns @jobs if no block_given.. so in effect we can use array
    # methods like this: jobs.each.last
    # is this hacky? Normal?
    def each
      @jobs.each do |job|
        yield job if block_given?
      end
    end

    def size
      @jobs.size
    end

    ##
    # === Description
    # convenience method for returning all (or part) of just the names of jobs
    def names name = ""
      find_all_by_name( name ).map(&:name)
    end

    ##
    # :method: find_by_
    # === Description
    # Implements find_by_ and find_all_by_ methods according to any method to
    # which that job responds.
    #
    # === Examples
    #   jobs.find_by_name "job_name"
    #
    #   jobs.find_all_by_url /svn/x

    ##
    # nodoc
    def method_missing sym, *args, &block # :nodoc:
      meth, name = missing_method_name( sym )
      if name
        self.send(meth) do |job|
          # I can't remember why I'm using union... :/
          # job.send(name).to_s.gsub(/-/, "_") =~ Regexp.union( args.map(&:to_s) )
          # args is an array because of method_missing. but find(_all)_by only
          # takes one parameter (for now..)
          # to_s for symbols, also removes warnings if given a regexp with options.
          arg = args.first.to_s #.gsub(/-/, "_")
          regex = Regexp.new(arg, Regexp::IGNORECASE)
          # gsub used so I can pass in symbols as names (which don't allow dashes
          # to_s as job.url returns a URI
          job.send(name).to_s.gsub(/-/, "_") =~ regex
        end
      else
        super sym, *args, &block
      end
    end

    def respond_to? sym
      missing_method_name sym or super sym
    end

    private
      def missing_method_name sym # :nodoc:
        # (find|find_all)_by_(name|url|...)
        [$1, $2] if sym.to_s =~ /^(.*)_by_(.*)$/ and Hudkins::Job.method_defined? $2
      end

  end
end
