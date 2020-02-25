# PSRead-JSONLD

Form a combined JSON-LD document from multiple parts via @id attributes

The objective for this was to store an organisation structure as code and split this between multiple files, allowing the parts to be modified and committed to a repository.

## Example

Original `example.organisation.json`

    {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Organisation Name",
    "alternateName": "Alternate Name",
    "url": "https://dommain.com",
    "logo": "",
    "department": [{
      "name": "Department One",
      "alternateName": "Head Office",
      "department": [{
        "@id": "https://domain.com/#payroll"
      }]
    }, {
      "name": "Department Two",
      "alternateName": "Satellite Office",
      "subOrganization": [{
        "@id": "https://domain.com/#human-resources"
      }]
    }]
  }


`.\Read-JSONLD.ps1 -File example.organisation.json`

Resulting PS Object piped to JSON:

    {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Organisation Name",
    "alternateName": "Alternate Name",
    "url": "https://dommain.com",
    "logo": "",
    "department": [{
        "name": "Department One",
        "alternateName": "Head Office",
        "department": [{
          "@context": "https://schema.org",
          "@type": "Organization",
          "@id": "https://domain.com/#payroll",
          "name": "Organisation Payroll",
          "alternateName": "Payroll",
          "url": "https://domain.com/",
          "telephone": "123321",
          "address": {
            "@type": "PostalAddress",
            "streetAddress": "1 Street",
            "addressLocality": "City",
            "addressRegion": "State",
            "postalCode": "60000"
          }
        }]
      },
      {
        "name": "Department Two",
        "alternateName": "Satellite Office",
        "subOrganization": [{
          "@context": "https://schema.org",
          "@type": "Organization",
          "@id": "https://domain.com/#human-resources",
          "name": "Organisation Human Resources",
          "alternateName": "HR",
          "url": "https://domain.com/",
          "telephone": "321123",
          "address": {
            "@type": "PostalAddress",
            "streetAddress": "2 Road",
            "addressLocality": "OtherCity",
            "addressRegion": "OtherState",
            "postalCode": "10000"
          }
        }]
      }]
    }
