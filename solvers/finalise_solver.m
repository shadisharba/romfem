function solution = finalise_solver(numerical_model_obj, global_fields, err_indicator, cycles_to_save)

solution = extract_relevant_info(numerical_model_obj, global_fields, err_indicator, cycles_to_save);
solution.results.err_indicator = err_indicator;

diary off

end