class Hapi::Jobs
  include Hapi::Common
  include Enumerable

  def initialize(hapi)
    @hapi = hapi
    data = @hapi.get_parsed( "/api/json" )
    @jobs = Array.new
    data["jobs"].each do |job|
      @jobs << Hapi::Job.new( @hapi, job )
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

  def names name = "."
    select do |job|
      job.name =~ Regexp.new(name, Regexp::IGNORECASE)
    end.
      map {|job| job.name}
  end

  def method_missing sym, *args, &block
    meth, name = missing_method_name( sym )
    if name
      self.send(meth) do |job|
        # gsub used so I can pass in symbols as names (which don't allow dashes
        job.send(name).to_s.gsub(/-/, "_") =~ Regexp.union( args.map(&:to_s) )
      end
    else
      super sym, *args, &block
    end
  end

  def respond_to? sym
    missing_method_name sym or super sym
  end

  private
    def missing_method_name sym
      # (find|find_all)_by_(name|url|...)
      [$1, $2] if sym.to_s =~ /^(.*)_by_(.*)$/ and Hapi::Job.method_defined? $2
    end

end
