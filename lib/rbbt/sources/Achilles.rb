require 'rbbt-util'
require 'rbbt/resource'

module Achilles
  extend Resource
  self.subdir = 'share/databases/Achilles'

  #def self.organism(org="Hsa")
  #  Organism.default_code(org)
  #end

  #self.search_paths = {}
  #self.search_paths[:default] = :lib

  BASE_URL = "http://portals.broadinstitute.org/achilles/datasets/19/download/"
  %w( cell_line_info.tsv   ceres_gene_effects.csv guide_activity_scores.tsv replicate_map.tsv sgRNA_mapping.tsv sgRNA_replicates_logFCnorm.csv).each do |filename|

    Achilles.claim Achilles['.source'][filename], :proc do |path|
      directory = File.dirname(path)
      FileUtils.mkdir_p directory unless File.exists? directory
      raise "Please register into Achilles and download the file #{filename} into #{path}"
    end

    basename, ext = filename.split(".")
    Achilles.claim Achilles[basename], :proc do |path|
      source = Achilles['.source'][filename].produce
      if ext == 'tsv'
        tsv = TSV.open(source, :header_hash => "", :type => :list)
      else
        tsv = TSV.open(source, :header_hash => "", :type => :list, :sep => ',')
        tsv.key_field = "Associated Gene Name"
      end
      tsv.to_s
    end
  end


end

if __FILE__ == $0
  Log.tsv Achilles["cell_line_info"].produce(true).find.tsv
end

