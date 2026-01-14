{ inputs, ... }:
final: prev: {
  worktrunk = inputs.worktrunk.packages.${prev.system}.default;
}

