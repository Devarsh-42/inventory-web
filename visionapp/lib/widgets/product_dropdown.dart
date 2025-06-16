import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/products_viewmodel.dart';

class ProductDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;
  final String? errorText;

  const ProductDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const CircularProgressIndicator();
        }

        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: 'Product',
            errorText: errorText,
          ),
          items: viewModel.products.map((Product product) {
            return DropdownMenuItem<String>(
              value: product.id,
              child: Text('${product.code} - ${product.name}'),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}