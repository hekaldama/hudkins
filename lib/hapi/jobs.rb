module Hapi
  class Jobs
    include Enumerable

    def initialize(hapi)
      @hapi = hapi
      data = @hapi.get_parsed( "/api/json" )
      @jobs = Array.new
      data["jobs"].each do |job|
        @jobs << Job.new( @hapi, job )
      end
    end

    def inspect
      # hide instance variables
      @hapi.class.object_inspect self, "@jobs=`#{@jobs.class}', ..."
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

    def method_missing sym, *args, &block
      if sym.to_s =~ /^find_by_(.*)/ and Job.method_defined? $1
        iv = $1
        self.find do |job|
          job.send(iv).to_s =~ Regexp.union( args.map(&:to_s) )
        end
      else
        super sym, *args, &block
      end
    end

    def respond_to? sym
      sym.to_s =~ /^find_by_(.*)/ and Job.method_defined? $1
    end

  end
end
