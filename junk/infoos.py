import os

for attribute_name in dir(os):
    attribute = getattr(os, attribute_name)
    print(f"\nAttribute: {attribute_name}\n{'=' * 40}")
    help(attribute)

