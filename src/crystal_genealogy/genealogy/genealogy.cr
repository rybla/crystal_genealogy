# Represents a single entry on a chromosome.
alias Gene = Int32
# Represents a collection of genes. Each member has exactly one.
alias Chromosome = Array(Gene)

# A single member of a genealogy.
struct Member
  property chromosome : Chromosome
  property children : Array(Member)

  def initialize
    @children = [] of Member
    @chromosome = [] of Gene
  end
end
