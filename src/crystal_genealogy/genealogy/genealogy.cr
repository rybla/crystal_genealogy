# Represents a single entry on a chromosome.
alias Gene = Int32
# Represents a collection of genes. Each member has exactly one.
alias Chromosome = Array(Gene)

# A single member of a genealogy.
struct Member
  # the collection of genes for this member.
  property chromosome : Chromosome
  # the members that were created subsequently as offspring, where this member was at least on of the parents.
  property children : Array(Member)

  def initialize
    @children = [] of Member
    @chromosome = [] of Gene
  end

  def gene(index : Int32) : Gene
    @chromosome[index]
  end
end
