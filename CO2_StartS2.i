
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 32
  xmin = 0
  xmax = 0.016
  ymin = 0.0
  ymax = 0.032
[]

[GlobalParams]
  PorousFlowDictator = 'dictator'
  gravity = '0 -9.81 0'
[]

[AuxVariables]
  [pressure_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [saturation_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [saturation_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [capillary_pressure]
    order = CONSTANT
    family = MONOMIAL
  []
  [density_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [brine_mass_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [co2_mass_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [brine_mass_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [nacl_mass_liquid]
    order = CONSTANT
    family = MONOMIAL
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [pressure_liquid]
    type = PorousFlowPropertyAux
    variable = pressure_liquid
    property = pressure
    phase = 0
    execute_on = timestep_end
  []
  [capillary_pressure]
    type = PorousFlowPropertyAux
    variable = capillary_pressure
    property = capillary_pressure
    execute_on = timestep_end
  []
  [saturation_liquid]
    type = PorousFlowPropertyAux
    variable = saturation_liquid
    property = saturation
    phase = 0
    execute_on = timestep_end
  []
  [density_liquid]
    type = PorousFlowPropertyAux
    variable = density_liquid
    property = density
    phase = 0
    execute_on = timestep_end
  []
  [saturation_gas]
    type = PorousFlowPropertyAux
    variable = saturation_gas
    property = saturation
    phase = 1
    execute_on = 'timestep_end'
  []
  [brine_mass_liquid]
    type = PorousFlowPropertyAux
    variable = brine_mass_liquid
    property = mass_fraction
    phase = 0
    fluid_component = 0
    execute_on = 'timestep_end'
  []
  [co2_mass_liquid]
    type = PorousFlowPropertyAux
    variable = co2_mass_liquid
    property = mass_fraction
    phase = 0
    fluid_component = 1
    execute_on = 'timestep_end'
  []
  [brine_mass_gas]
    type = PorousFlowPropertyAux
    variable = brine_mass_gas
    property = mass_fraction
    phase = 1
    fluid_component = 0
    execute_on = 'timestep_end'
  []
  [nacl_mass_liquid]
    type = PorousFlowPropertyAux
    variable = nacl_mass_liquid
    property = mass_fraction
    phase = 0
    fluid_component = 2
    execute_on = 'timestep_end'
  []
  [perm_times_app]
    type = PorousFlowPropertyAux
    variable = perm
    property = permeability
    row = 0
    column = 0
  []
[]
[ICs]
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.2
    max = 0.4
  []
[]

[Variables]
  [pgas]
    initial_condition = 1e7
    scaling = 1e-7
  []
  [zi]
    initial_condition = 0
  []
  [xnacl]
    initial_condition = 0.24
  []
[]

[Kernels]
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pgas
  []
  [flux0]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = pgas
  []
  [diff0]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = pgas
    disp_long = '0 0'
    disp_trans = '0 0'
  []
  [mass1]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = zi
  []
  [flux1]
    type = PorousFlowAdvectiveFlux
    fluid_component = 1
    variable = zi
  []
  [diff1]
    type = PorousFlowDispersiveFlux
    fluid_component = 1
    variable = zi
    disp_long = '0 0'
    disp_trans = '0 0'
  []
  [mass2]
    type = PorousFlowMassTimeDerivative
    fluid_component = 2
    variable = xnacl
  []
  [flux2]
    type = PorousFlowAdvectiveFlux
    fluid_component = 2
    variable = xnacl
  []
  [diff2]
    type = PorousFlowDispersiveFlux
    fluid_component = 2
    variable = xnacl
    disp_long = '0 0'
    disp_trans = '0 0'
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pgas zi xnacl'
    number_fluid_phases = 2
    number_fluid_components = 3
  []
  [pc]
   # type = PorousFlowCapillaryPressureVG
   # alpha = 1e-3
   # m = 0.5
   # sat_lr = 0.1
   type = PorousFlowCapillaryPressureConst
   pc = 0
  []
  [fs]
    type = PorousFlowBrineCO2
    brine_fp = brine
    co2_fp = co2
    capillary_pressure = pc
  []
[]

[Modules]
  [FluidProperties]
    [co2sw]
      type = CO2FluidProperties
    []
    [co2]
      type = TabulatedFluidProperties
      fp = co2sw
    []
    [water]
      type = Water97FluidProperties
    []
    [watertab]
      type = TabulatedFluidProperties
      fp = water
      temperature_min = 273.15
      temperature_max = 700.15
      pressure_min = 1e5
      pressure_max = 3e7
      fluid_property_file = water_fluid_properties.csv
      save_file = false
    []
    [brine]
      type = BrineFluidProperties
      water_fp = watertab
    []
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
    temperature = '45'
  []
  [brineco2]
    type = PorousFlowFluidState
    gas_porepressure = 'pgas'
    z = 'zi'
    temperature_unit = Celsius
    xnacl = 'xnacl'
    capillary_pressure = pc
    fluid_state = fs
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = porosity
  []
  [permeability]
    type = PorousFlowPermeabilityKozenyCarman
    k0 = 1E-14
    poroperm_function = kozeny_carman_phi0
    m = 0
    n = 3
    phi0 = 0.11
  []
  [relperm_liquid]
    type = PorousFlowRelativePermeabilityVG
    m = 0.5
    phase = 0
    s_res = 0.1
    sum_s_res = 0.15
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 1
    s_res = 0.05
    sum_s_res = 0.15
  []
  [diffusivity]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '2e-9 2e-9 2e-9 2e-9 1e-9 1e-9'
    tortuosity = '1 1'
  []
[]

[BCs]
  [injection]
    type = PorousFlowSink
    variable = zi
    flux_function = -5.3e-5
    boundary = 'top'
  []
  [bottomco2liq]
    type = PorousFlowPiecewiseLinearSink
    boundary = 'bottom'
    variable = zi
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 0
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 1
    use_relperm = true
  []
  [bottomco2gas]
    type = PorousFlowPiecewiseLinearSink
    variable = zi
    boundary = 'bottom'
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 1
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 1
    use_relperm = true
  []
  [bottomwaterliq]
    type = PorousFlowPiecewiseLinearSink
    boundary = 'bottom'
    variable = pgas
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 0
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 0
    use_relperm = true
  []
  [bottomwatergas]
    type = PorousFlowPiecewiseLinearSink
    variable = pgas
    boundary = 'bottom'
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 1
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 0
    use_relperm = true
  []
  [bottomnaclliq]
    type = PorousFlowPiecewiseLinearSink
    boundary = 'bottom'
    variable = xnacl
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 0
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 2
    use_relperm = true
  []
  [bottomnaclg]
    type = PorousFlowPiecewiseLinearSink
    variable = xnacl
    boundary = 'bottom'
    use_mobility = true
    PorousFlowDictator = dictator
    fluid_phase = 1
    multipliers = '0 1e9'
    PT_shift = '1e7'
    pt_vals = '0 1e9'
    mass_fraction_component = 2
    use_relperm = true
  []
[]

[Preconditioning]
  active = 'basic'
  [basic]
    type = SMP
    full = true
    petsc_options = '-snes_converged_reason -ksp_diagonal_scale -ksp_diagonal_scale_fix -ksp_gmres_modifiedgramschmidt'
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = 'gmres asm lu NONZERO 2'
  []
  [preferred]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = 'lu mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 10000
  nl_max_its = 25
  l_max_its = 10
  l_abs_tol = 1e-8
  nl_abs_tol = 1e-5
  dtmax = 5
  line_search = 'none'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    growth_factor = 1.3
    cutback_factor = 0.7
  []
[]

[Outputs]
  exodus = true
[]