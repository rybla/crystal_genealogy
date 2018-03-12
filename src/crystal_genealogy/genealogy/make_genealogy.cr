require "../genealogy"

# creates a (randomized) `Genealogy` given the input parameters
def make_genealogy(parameters : Parameters) : Genealogy
  genealogy = Genealogy::Genealogy.new parameters
  genealogy.make_genealogy
  genealogy
end
