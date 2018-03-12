require "random"
random = Random.new

module Genealogy
  alias Index = UInt32
  alias Fitness = UInt32
  # an array of `Member`s
  alias Generation = Array(Member)
  # parameters for a `Genealogy`.
  alias Parameters = {generation_count: UInt32, generation_size: UInt32, parent_count: UInt32, gene_count: UInt32, allele_count: UInt32, age_factor: Float32, popular_factor: Float32, genetic_factor: Float32}
  # A single entry on a chromosome.
  alias Gene = UInt8
  # A collection of genes. Each member has exactly one.
  alias Chromosome = Array(Gene)

  # A single member of a genealogy.
  struct Member
    # the collection of genes for this member.
    property chromosome : Chromosome
    # the members that were created subsequently as offspring, where this member was at least on of the parents.
    property children : Array(Member)

    def initialize(gene_count)
      @chromosome = Chromosome.new(gene_count) { 0 }
      @children = Array(Member).new
    end

    def gene(ind : Index) : Gene
      @chromosome[ind]
    end

    def set_gene(ind : Index, gene : Gene) : Nil
      @chromosome[ind] = allele
    end

    def fitness : Fitness
      10_u32
    end
  end

  struct Genealogy
    # all members created during the same generation index in a genealogy.
    property generations : Array(Generation)
    # the input parameters to this genealogy.
    getter parameters

    # makes a new, blank genealogy.
    # fills genealogy with blank members.
    def initialize(@parameters : Parameters)
      gen_size = @parameters[:generation_size]
      gene_count = @parameters[:gene_count]
      @generations = Array(Generation).new(@parameters[:generation_count]) {
        Generation.new(gen_size) { Member.new gene_count }
      }
    end

    # gets the `Generation` at a generation index.
    def generation_at(gen_ind : Index) : Generation
      @generations[gen_ind]
    end

    # gets the `Member` at a member index within the generation at a generation index.
    def member_at(gen_ind : Index, mem_ind : Index) : Member
      @generations[gen_ind][mem_ind]
    end

    # gets the `Member` at a member index within the generation at a generation index.
    def member_at(index : Index) : Member
      self.member_at(index / @parameters[:generation_count],
        index % @parameters[:generation_size])
    end

    def make_genealogy : Nil
      @parameters[:generation_count].times do |i|
        self.make_generation i
      end
    end

    # makes the `Generation`, based on the current state of the `Genealogy`.
    def make_generation(gen_ind : Index) : Nil
      if gen_ind == 0
        # special first generation
        @parameters[:generation_size].times do |i|
          self.make_random_member gen_ind, i
        end
      else
        # normal, subsequent generation
        @parameters[:generation_size].times do |i|
          self.make_member gen_ind, i
        end
      end
    end

    # makes a random `Member`, not based on current state of the `Genealogy`.
    # used for filling the first generation.
    def make_random_member(gen_ind : Index, mem_ind : Index) : Nil
      mem = self.member gen_ind, mem_ind
      # choose random alleles for each gene
      allele_count = @parameters[:allele_count]
      @parameters[:gene_count].times do |gene|
        mem.set_gene gene, random.rand(allele_count)
      end
    end

    # makes the `Member`, based on the current state of the `Genealogy`.
    def make_member(gen_ind : Index, mem_ind : Index) : Nil
      # get all possible parents
      gen_size = @parameters[:generation_size]
      gen_count = @parameters[:generation_count]
      total_fitness = 0
      member_fitnesses = Array(UInt32).new(gen_ind * gen_size) { |i|
        total_fitness += self.member_at(i).fitness
        total_fitness
      }
      # inherit genes
      self.inherit_genes(
        self.member_at(gen_ind, mem_ind),
        # from chosen parents
        self.choose_parents(fitness_total, member_fitnesses)
      )
    end

    # chooses the parents for the `Member`, _with replacement_.
    def choose_parents(
      fitness_total : Fitness,
      member_fitnesses : Array(Fitness)
    ) : Array(Member)
      parent_count = @parameters[:parent_count]
      parents = Array(Member).new(parent_count)
      choices = Array(Member).new(parent_count) { random.rand fitness_total }.sort

      parent_ind = 0
      member_ind = 0
      choices_ind = 0
      member_fitnesses.map { |fitness|
        while fitness > choices[choices_ind]
          parents[parent_ind] = self.member_at member_ind
          # TODO: add children to parent
          choices_ind += 1
          parent_ind += 1
        end
      }

      return parents
    end

    # gives the child `Member` some genes based on parents' genetics.
    # a parent is selected at random for each gene to inherit.
    def inherit_genes(member : Member, parents : Array(Member)) : Nil
      parent_count = @parameters[:parent_count]
      @parameters[:gene_count].times do |i|
        member.set_gene i parents[random.rand parent_count].gene(i)
      end
    end
  end
end
