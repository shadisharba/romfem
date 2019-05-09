function plastic_multiplier = evaluate_plastic_multiplier(material, yield_function)
plastic_multiplier = (yield_function ./ material.user_material.k).^material.user_material.n;
end