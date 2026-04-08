function Wmat = bootstrap(truetime)
    numSamples = 5000;
    moms_boot = zeros(numSamples, 21); %hardcode len of moments
    for sample = 1:numSamples
        resample = datasample(truetime,height(truetime));
        moms_boot(sample,:) = table2array(moms(resample));
    end
    Wmat = cov(moms_boot);
end

