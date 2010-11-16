class Hapi::Jobs < Hapi::Common
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
    # hide instance variables
    foo_inspect + "@jobs=`#{@jobs.class}', ..."
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
    if iv = missing_method_test( sym )
      self.find do |job|
        job.send(iv).to_s =~ Regexp.union( args.map(&:to_s) )
      end
    else
      super sym, *args, &block
    end
  end

  def respond_to? sym
    missing_method_test sym or super
  end

  private
    def missing_method_test sym
      $1 if sym.to_s =~ /^find_by_(.*)/ and Hapi::Job.method_defined? $1
    end

end
